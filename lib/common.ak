use cardano/address.{Address, StakeCredential}
use cardano/assets.{AssetName, PolicyId, quantity_of}
use cardano/transaction.{Input, Output}

pub fn is_user_allowed(
  input: Input,
  userStakeCredential: StakeCredential,
  userTokenPolicyId: PolicyId,
  userTokenAssetName: AssetName,
) {
  expect Some(refInputStakeCredential) = input.output.address.stake_credential
  and {
    refInputStakeCredential == userStakeCredential,
    quantity_of(input.output.value, userTokenPolicyId, userTokenAssetName) > 0,
  }
}
