use aiken/collection/dict.{is_empty}
use cardano/address.{Address, StakeCredential}
use cardano/assets.{AssetName, PolicyId, quantity_of, tokens}
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

pub fn input_contains_any_token_with_policy_id(
  input: Input,
  policy_id: PolicyId,
) {
  is_empty(tokens(input.output.value, policy_id)) == False
}
