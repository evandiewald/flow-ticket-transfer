import NonFungibleTicket from 0xf8d6e0586b0a20c7

// This transaction configures a user's account
// to use the NFT contract by creating a new empty collection,
// storing it in their account storage, and publishing a capability
transaction {
  prepare(acct: AuthAccount) {

    // Create a new empty collection
    let collection <- NonFungibleTicket.createEmptyCollection()

    // store the empty NFT Collection in account storage
    acct.save<@NonFungibleTicket.Collection>(<-collection, to: /storage/NFTCollection)

    log("Collection created for account 2")

    // create a public capability for the Collection
    acct.link<&{NonFungibleTicket.NFTReceiver}>(/public/NFTReceiver, target: /storage/NFTCollection)

    log("Capability created")
  }
}