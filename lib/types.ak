use aiken/transaction/credential.{Address}
use aiken/transaction/value.{AssetName, PolicyId}

pub type SecurityDatum {
  securityId: ByteArray,
  securityPolicyId: PolicyId,
  securityAssetName: AssetName,
  name: ByteArray,
  isin: ByteArray,
  issuer: Address,
  issueDate: Int,
  maturityDate: Int,
}