using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Photon.VR;
using TMPro;
using PlayFab.ClientModels;
using PlayFab;
using Photon.Pun;

public class NameScriptUI : MonoBehaviour
{
 [Header("DONT KNOW WHO MADE THE SCRIPT ")]
    [Space]
    [Header("EDITED BY M12 DONT NEED CREDITS :) ")]
    [Space]

    public string NameVar;
    public string CurrentName;
    public string PhotonName;
    [Space]
    public TextMeshProUGUI NameText;
    public TextMeshProUGUI CurrrentNameText;
    public TextMeshProUGUI PhotonNameText;


  

    private void Update()
    {
        if (NameVar.Length > 12)
        {
            NameVar = NameVar.Substring(0, 12);          
        }

        CurrentName = NameVar;

        NameText.text = NameVar;

        PhotonName = PhotonNetwork.LocalPlayer.NickName;

        PhotonNameText.text = PhotonName;
    }


    public void EnterName()
    {
        CurrrentNameText.text = CurrentName;

        NameVar = CurrentName; 

        PhotonVRManager.SetUsername(CurrentName);

    }

    public void NoName()
    {
        if (string.IsNullOrEmpty(NameVar))
        {
         
            CurrentName = "Chimp" + Random.Range(1, 10000).ToString();

            EnterName();
        }               
    }
}
