//There is an instance of this SC for each admin token (PolicyId+AssetName), which also means there's an instance of this SC
//for each type of security tokens.
//This SC produces user status tokens that must never leave this SC.
//The token AssetName must always be the same and it's determined by the transfer_manager parameter.
use aiken/collection/list.{foldl, length}
use aiken/crypto.{Blake2b_224, Hash}
use cardano/address.{Address, Credential, Inline, Script, StakeCredential}
use cardano/assets.{AssetName, PolicyId, flatten, quantity_of}
use cardano/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction,
}
use common.{is_user_allowed}
use types.{
  LockedTransferDatum, SecurityDatum, StateManagerDatum,
  StateManagerMintRedeemer, StateManagerSpendRedeemer,
}
use utils.{
  get_inputs_from_sc, get_outputs_with_token, get_own_hash, is_output_to_sc,
  must_be_signed_by_stake_credential,
}

validator state_manager(
  adminTokenPolicyId: PolicyId,
  adminTokenAssetName: AssetName,
) {
  mint(
    redeemer: StateManagerMintRedeemer,
    policy_id: PolicyId,
    self: Transaction,
  ) {
    expect Some(adminRefInput) =
      list.at(self.reference_inputs, redeemer.adminTokenRefInputIndex)
    expect Some(stateManagerOutput) =
      list.at(self.outputs, redeemer.stateManagerOutputIndex)
    and {
      must_be_signed_by_stake_credential(self, redeemer.adminStakeCredential),
      is_user_allowed(
        adminRefInput,
        redeemer.adminStakeCredential,
        adminTokenPolicyId,
        adminTokenAssetName,
      ),
      quantity_of(self.mint, policy_id, adminTokenAssetName) == 1,
      quantity_of(stateManagerOutput.value, policy_id, adminTokenAssetName) == 1,
      is_output_to_sc(stateManagerOutput, policy_id),
      length(flatten(stateManagerOutput.value)) <= 21,
    }
  }

  else(_) {
    fail
  }
}
