use aiken/crypto.{Blake2b_224, Hash, VerificationKey}
use cardano/address.{Credential, StakeCredential}
use cardano/assets.{AssetName, PolicyId}

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

pub type SecurityInfoDatum {
  securityInfo: SecurityInfo,
  issuerTokenAssetName: AssetName,
  securityPolicyId: PolicyId,
  securityAssetName: AssetName,
  remainingSecurityTokens: Int,
}

pub type SecurityInfoMintRedeemer {
  securityInfoOutputIndex: Int,
}

pub type SecurityInfoSpendRedeemer {
  issuerTokenRefInputIndex: Int,
  issuerStakeCredential: StakeCredential,
  currentSecurityInfoIndex: Int,
}

pub type AdminManagerDatum {
  issuerAssetName: AssetName,
}

pub type AdminManagerMintRedeemer {
  issuerStakeCredential: StakeCredential,
  issuerRefInputIndex: Int,
  adminManagerOutputIndex: Int,
}

pub type AdminManagerSpendRedeemer {
  issuerStakeCredential: StakeCredential,
  issuerRefInputIndex: Int,
}

pub type StateManagerData {
  adminAssetName: AssetName,
}

pub type StateManagerDatum {
  credential: Credential,
  data: StateManagerData,
}

pub type StateManagerMintRedeemer {
  adminStakeCredential: StakeCredential,
  adminTokenRefInputIndex: Int,
  stateManagerOutputIndex: Int,
}

pub type StateManagerSpendRedeemer {
  adminStakeCredential: StakeCredential,
  adminTokenRefInputIndex: Int,
}

pub type TransferManagerDatum {
  userStateAssetName: AssetName,
  data: Option<Data>,
}

pub type TransferManagerMintRedeemer {
  issuerStakeCredential: StakeCredential,
  issuerTokenRefInputIndex: Int,
  transferManagerOutputIndex: Int,
  transferAmount: Int,
}

pub type TransferManagerSpendRedeemer {
  withdrawIndex: Int,
}

pub type TransferOutput {
  credential: Credential,
  amount: Int,
  receiverStateIndex: Int,
}

pub type TransferManagerWithdrawRedeemer {
  Transfer {
    outputsDetails: List<TransferOutput>,
    firstOutputIndex: Int,
    totalInputAmount: Int,
    ownerStateIndex: Int,
    //StakeCredential of the owner of the utxos that are being transferred
    ownerStakeCredential: StakeCredential,
  }
  LockTokens {
    //StakeCredential of the owner of the utxos that are being transferred
    adminStakeCredential: StakeCredential,
    //index in the reference input list
    adminRefInputIndex: Int,
    //amount of tokens to lock
    lockedTokensAmount: Int,
    //index in the output list that go to the locked_transfer_manager
    lockingOutputIndex: Int,
    //index in the output list that contains the change if any
    changeOutputIndex: Int,
    //StakeCredential of the last user that was owning these tokens
    lastUserStakeCredential: StakeCredential,
  }
}

pub type LockedTransferDatum {
  ownerStakeCredential: StakeCredential,
  tranferManagerScriptHash: Hash<Blake2b_224, VerificationKey>,
  tokenAssetName: AssetName,
}

pub type LockedTransferManagerSpendRedeemer {
  withdrawIndex: Int,
}

pub type LockedTransferManagerWithdrawRedeemer {
  tranferManagerScriptHash: ByteArray,
  tokenAssetName: AssetName,
  unlockedTokensAmount: Int,
  unlockingOutputIndex: Int,
  changeOutputIndex: Int,
  newUserStakeCredential: StakeCredential,
  changeUserStakeCredential: StakeCredential,
}
