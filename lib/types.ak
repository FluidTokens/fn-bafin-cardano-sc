use aiken/transaction/value.{AssetName, PolicyId}

pub type SecurityDatum {
  securityId: ByteArray,
  securityPolicyId: PolicyId,
  securityAssetName: AssetName,
  name: ByteArray,
  isin: ByteArray,
  issuerTokenPolicyId: PolicyId,
  issuerTokenAssetName: AssetName,
  issueDate: Int,
  maturityDate: Int,
}
