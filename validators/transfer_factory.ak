use aiken/bytearray
use aiken/hash.{sha2_256}
use aiken/list.{length}
use aiken/transaction.{
  Input, Mint, OutputReference, ScriptContext, ScriptPurpose, TransactionId,
}
use aiken/transaction/credential.{Address, ScriptCredential}
use aiken/transaction/value.{
  AssetName, PolicyId, flatten, from_minted_value, quantity_of,
}

//we pass in the redeemer the transaction to look for
type Redeemer {
  MintTokens { issuerTokenInputIndex: Int }
}

validator(
  _securityId: ByteArray,
  _name: ByteArray,
  _isin: ByteArray,
  _issuer: Address,
  _issueDate: Int,
  _maturityDate: Int,
  issuerTokenPolicyId: PolicyId,
  issuerTokenAssetName: AssetName,
) {
  fn minter(redeemer: Redeemer, ctx: ScriptContext) {
    expect Some(issuerTokenInput) =
      list.at(ctx.transaction.inputs, redeemer.issuerTokenInputIndex)
    quantity_of(
      issuerTokenInput.output.value,
      issuerTokenPolicyId,
      issuerTokenAssetName,
    ) > 0
  }
}
