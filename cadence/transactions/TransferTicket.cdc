import NonFungibleTicket from 0xf8d6e0586b0a20c7

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction {

    // The field that will hold the NFT as it is being
    // transferred to the other account
    let transferToken: @NonFungibleTicket.NFT
    let metadata: { String : String }

    prepare(acct: AuthAccount) {

        // Borrow a reference from the stored collection
        let collectionRef = acct.borrow<&NonFungibleTicket.Collection>(from: /storage/NFTCollection)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.metadata = collectionRef.getMetadata(id: 1)
        // Call the withdraw function on the sender's Collection
        // to move the NFT out of the collection
        self.transferToken <- collectionRef.withdraw(withdrawID: 1)
    }

    execute {
        // Get the recipient's public account object
        let recipient = getAccount(0x01cf0e2f2f715450)

        // Get the Collection reference for the receiver
        // getting the public capability and borrowing a reference from it
        let receiverRef = recipient.getCapability<&{NonFungibleTicket.NFTReceiver}>(/public/NFTReceiver)
            .borrow()
            ?? panic("Could not borrow receiver reference")
        
        // Deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-self.transferToken, metadata: self.metadata)

        log("NFT ID 1 transferred from account 2 to account 1")
    }
}