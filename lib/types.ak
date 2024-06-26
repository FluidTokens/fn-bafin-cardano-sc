use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction/credential.{Script, StakeCredential}
use aiken/transaction/value.{AssetName, PolicyId}

pub type SecurityInfo {
  isin: ByteArray,
  termOfIssue: ByteArray,
  securityType: ByteArray,
  securityForm: ByteArray,
  securityClass: ByteArray,
  recordKeeping: ByteArray,
  entryType: ByteArray,
  withoutVotingRights: Bool,
  transferRestrictions: Bool,
  thirdPartyRights: Bool,
  companyConsent: Bool,
  participateSettlement: Bool,
  paymentbond: ByteArray,
  dividendPaymentFrequency: ByteArray,
  //total number of tokens
  volumeOfIssuance: Int,
  nominalAmount: Int,
  issuerName: ByteArray,
  issuerRegistration: ByteArray,
  cryptoSecurityRegister: ByteArray,
  shareCustodian: ByteArray,
  tokenCustodian: ByteArray,
}

pub type SecurityDatum {
  securityInfo: SecurityInfo,
  securityPolicyId: PolicyId,
  securityAssetName: AssetName,
  issuerTokenPolicyId: PolicyId,
  issuerTokenAssetName: AssetName,
  remainingSecurityTokens: Int,
}

pub type TransferDatum {
  i: Int,
}

pub type LockedTransferDatum {
  ownerStakeCredential: StakeCredential,
  tranferManagerScriptHash: Hash<Blake2b_224, Script>,
  tokenPolicyId: PolicyId,
  tokenAssetName: AssetName,
}
