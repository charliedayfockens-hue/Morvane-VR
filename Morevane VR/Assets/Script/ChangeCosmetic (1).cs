using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Photon.VR;

public class ChangeCosmetic : MonoBehaviour
{
    [Header("This script was made by ConCon")]
    [Header("You do not have to give credits")]
    public string Slot;
    public string CosmeticName;

    private bool isEquipped = false;

    private void OnTriggerEnter(Collider other)
    {
        if (!other.gameObject.CompareTag("HandTag"))
            return;

        if (isEquipped)
        {
            // Unequip / clear the cosmetic
            PhotonVRManager.SetCosmetic(Slot, "");
            isEquipped = false;
        }
        else
        {
            // Equip the cosmetic
            PhotonVRManager.SetCosmetic(Slot, CosmeticName);
            isEquipped = true;
        }
    }
}
