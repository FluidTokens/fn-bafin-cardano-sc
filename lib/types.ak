use aiken/transaction/credential.{Address}
use aiken/transaction/value.{AssetName, PolicyId}

pub type SecurityDatum {
  securityId: ByteArray,
  name: ByteArray,
  isin: ByteArray,
  issuer: Address,
  issueDate: Int,
  maturityDate: Int,
}

pub type AccountDatum {AccountDatum}
