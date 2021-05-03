
import NonFungibleTicket from 0xf8d6e0586b0a20c7

pub fun main() : [UInt64] {
    let acct1 = getAccount(0xf8d6e0586b0a20c7)
    // log("NFT Owner")    
    let capability1 = acct1.getCapability<&{NonFungibleTicket.NFTReceiver}>(/public/NFTReceiver)

    let receiverRef1 = capability1.borrow()
        ?? panic("Could not borrow the receiver reference")

    return receiverRef1.getIDs()
}