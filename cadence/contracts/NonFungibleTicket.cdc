// NonFungibleTicket.cdc
// contract to manage unique tradeable tickets (based on Flow NFT standard)
// see: https://docs.onflow.org/cadence/tutorial/04-non-fungible-tokens/

pub contract NonFungibleTicket {

    // set up a couple events for key deposits/withdrawals
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    // our NFT (Non-Fungible-Ticket) is simply defined by an id. metadata coming later
    pub resource NFT {
        pub let id: UInt64
        // we want to make our ticket non-transferrable, so let's keep track of how many times it has changed hands
        pub var numTransfers : UInt64

        init(initID: UInt64) {
            self.id = initID
            self.numTransfers = 0
        }
        // we will need a function to iterate the number of transfers each time
        pub fun transfer() {
            self.numTransfers = self.numTransfers + 1 as UInt64
        }
    }

    // receiver interface allows others to interact w certain functions via public access
    pub resource interface NFTReceiver {
        pub fun deposit(token: @NFT, metadata: {String : String})
        pub fun getIDs(): [UInt64]
        pub fun idExists(id: UInt64): Bool
        pub fun getMetadata(id: UInt64) : {String : String}
        // obviously, we don't allow public access to withdraw/minting functions
    }

    // defining a Collection resource for all our tickets
    pub resource Collection: NFTReceiver {
        pub var ownedNFTs: @{UInt64: NFT}
        pub var metadataObjs: {UInt64: { String : String }}

        init () {
            self.ownedNFTs <- {}
            self.metadataObjs = {}
        }

        // withdraw forced to be non-nil. function throws error if NFT with withdrawID doesn't exist
        pub fun withdraw(withdrawID: UInt64): @NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID)!

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <- token
        }

        // the deposit function is a bit more complex. first of all, this is where the metadata comes in:
        pub fun deposit(token: @NFT, metadata: {String : String}) {
            // our token can be transferred no more than once (from admin to attendee)
            if token.numTransfers > (1 as UInt64) {
                panic("Ticket is non-transferrable!")
            }
            self.metadataObjs[token.id] = metadata

            emit Deposit(id: token.id, to: self.owner?.address)
            // log the transfer (increases numTransfers by 1)
            token.transfer()
            self.ownedNFTs[token.id] <-! token
        }

        // rest of these are pretty straightforward
        pub fun idExists(id: UInt64): Bool {
            return self.ownedNFTs[id] != nil
        }


        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun updateMetadata(id: UInt64, metadata: {String: String}) {
            self.metadataObjs[id] = metadata
        }

        pub fun getMetadata(id: UInt64): {String : String} {
            return self.metadataObjs[id]!
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // will need to create an empty collection for any account that wants our NFT
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    // can explicitly share NFTMinter resource with another admin so that they can mint tickets
    pub resource NFTMinter {
        pub var idCount: UInt64

        init() {
            self.idCount = 1
        }

        pub fun mintNFT(): @NFT {
            var newNFT <- create NFT(initID: self.idCount)
            self.idCount = self.idCount + 1 as UInt64
            return <-newNFT
        }

    }

    // launching the contract does 3 things: 
    init() {
        // 1) save a fresh collection to the admin's storage
        self.account.save(<-self.createEmptyCollection(), to: /storage/NFTCollection)

        // 2) allow public access to NFTReceiver functions through this reference
        self.account.link<&{NFTReceiver}>(/public/NFTReceiver, target: /storage/NFTCollection)

        // 3) save NFTMinter resource to private storage
        self.account.save(<-create NFTMinter(), to: /storage/NFTMinter)
    }


}
 