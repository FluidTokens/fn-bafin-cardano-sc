use aiken/collection/list.{length}
use cardano/assets.{AssetName, PolicyId, flatten, quantity_of}
use cardano/transaction.{Output, OutputReference, Transaction}
use common.{is_user_allowed}
use types.{
  AdminManagerDatum, AdminManagerMintRedeemer, AdminManagerSpendRedeemer,
}
use utils.{is_output_to_sc, must_be_signed_by_stake_credential}

validator admin_manager(issuerManagerHash: PolicyId) {
  mint(
    redeemer: AdminManagerMintRedeemer,
    policy_id: PolicyId,
    self: Transaction,
  ) {
    expect Some(issuerRefInput) =
      list.at(self.reference_inputs, redeemer.issuerRefInputIndex)
    expect Some(adminManagerOutput) =
      list.at(self.outputs, redeemer.adminManagerOutputIndex)
    and {
      must_be_signed_by_stake_credential(self, redeemer.issuerStakeCredential),
      is_user_allowed(
        issuerRefInput,
        redeemer.issuerStakeCredential,
        issuerManagerHash,
        issuerAssetName,
      ),
      quantity_of(self.mint, policy_id, issuerAssetName) == 1,
      quantity_of(adminManagerOutput.value, policy_id, issuerAssetName) == 1,
      is_output_to_sc(adminManagerOutput, policy_id),
      length(flatten(adminManagerOutput.value)) <= 5,
    }
  }

  spend(
    _datumOpt: Option<AdminManagerDatum>,
    redeemer: AdminManagerSpendRedeemer,
    _input: OutputReference,
    self: Transaction,
  ) {
    expect Some(issuerRefInput) =
      list.at(self.reference_inputs, redeemer.issuerRefInputIndex)
    and {
      must_be_signed_by_stake_credential(self, redeemer.issuerStakeCredential),
      is_user_allowed(
        issuerRefInput,
        redeemer.issuerStakeCredential,
        issuerManagerHash,
        issuerAssetName,
      ),
    }
  }

  else(_) {
    fail
  }
}
