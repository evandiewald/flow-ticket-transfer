import NonFungibleTicket from 0xf8d6e0586b0a20c7

// This transaction configures a user's account
// to use the NFT contract by creating a new empty collection,
// storing it in their account storage, and publishing a capability
transaction {


    // The reference to the Minter resource stored in account storage

    prepare(acct: AuthAccount) {
        // Get the owner's collection capability and borrow a reference
        let collection <- acct.load<@NonFungibleTicket.Collection>(from: /storage/NFTCollection)!
        destroy collection

    }

    execute {
        
        // Use the minter reference to mint an NFT, which deposits
        // the NFT into the collection that is sent as a parameter.
    // Create a new empty collection
    
  }
}