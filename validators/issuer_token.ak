use aiken/bytearray
use aiken/hash.{sha2_256}
use aiken/list.{length}
use aiken/transaction.{
  Input, Mint, OutputReference, ScriptContext, ScriptPurpose, TransactionId,
}
use aiken/transaction/credential.{ScriptCredential}
use aiken/transaction/value.{
  AssetName, PolicyId, flatten, from_minted_value, quantity_of,
}

//we pass in the redeemer the transaction to look for
type Redeemer {
  MintTokens { adminTokenInputIndex: Int }
}

validator(
  issuerId: ByteArray,
  adminTokenPolicyId: PolicyId,
  adminTokenAssetName: AssetName,
) {
  fn minter(redeemer: Redeemer, ctx: ScriptContext) {
    expect Some(adminTokenInput) =
      list.at(ctx.transaction.inputs, redeemer.adminTokenInputIndex)
    quantity_of(
      adminTokenInput.output.value,
      adminTokenPolicyId,
      adminTokenAssetName,
    ) > 0
  }
}
