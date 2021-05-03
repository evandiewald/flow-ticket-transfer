import NonFungibleTicket from 0xf8d6e0586b0a20c7

// This transaction allows the Minter account to mint an NFT
// and deposit it into its collection.

transaction {

    // The reference to the collection that will be receiving the NFT
    let receiverRef: &{NonFungibleTicket.NFTReceiver}

    // The reference to the Minter resource stored in account storage
    let minterRef: &NonFungibleTicket.NFTMinter

    prepare(acct: AuthAccount) {
        // Get the owner's collection capability and borrow a reference
        self.receiverRef = acct.getCapability<&{NonFungibleTicket.NFTReceiver}>(/public/NFTReceiver)
            .borrow()
            ?? panic("Could not borrow receiver reference")

        // Borrow a capability for the NFTMinter in storage
        self.minterRef = acct.borrow<&NonFungibleTicket.NFTMinter>(from: /storage/NFTMinter)
            ?? panic("Could not borrow minter reference")
    }

    execute {
        // Use the minter reference to mint an NFT, which deposits
        // the NFT into the collection that is sent as a parameter.
        let newNFT <- self.minterRef.mintNFT()

        let metadata : {String : String} = {
            "event": "FLOW LIVE in Concert!",
            "section": "200", 
            "row": "3", 
            "seat": "1",
            "uri": "https://flow-ticket-exchange.s3.amazonaws.com/ticket.png"
        }

        self.receiverRef.deposit(token: <-newNFT, metadata: metadata)

        log("Ticket minted and deposited into admin account")
    }
}