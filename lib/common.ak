use aiken/transaction.{Input, Output}
use aiken/transaction/credential.{Address, StakeCredential}
use aiken/transaction/value.{AssetName, PolicyId, quantity_of}

pub fn is_user_allowed(
  userRefInput: Input,
  stakeCredential: StakeCredential,
  issuerTokenPolicyId: PolicyId,
  issuerTokenAssetName: AssetName,
) {
  expect Some(refInputStakeCredential) =
    userRefInput.output.address.stake_credential
  and {
    refInputStakeCredential == stakeCredential,
    quantity_of(
      userRefInput.output.value,
      issuerTokenPolicyId,
      issuerTokenAssetName,
    ) > 0,
  }
}
