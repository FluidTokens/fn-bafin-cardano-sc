use aiken/bytearray
use aiken/hash.{sha2_256}
use aiken/list.{length}
use aiken/transaction.{
  Input, Mint, OutputReference, ScriptContext, ScriptPurpose, TransactionId,
}
use aiken/transaction/credential.{Address, ScriptCredential}
use aiken/transaction/value.{flatten, from_minted_value}
use utils.{must_be_signed_by}

//we pass in the redeemer the transaction to look for
type Redeemer {
  MintTokens
}

validator(masterAdminAddress: Address) {
  fn minter(redeemer: Redeemer, ctx: ScriptContext) {
    must_be_signed_by(ctx.transaction, masterAdminAddress)
  }
}
