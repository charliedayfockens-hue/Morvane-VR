using UnityEngine;
using System.Collections.Generic;
using Photon.Pun;
using PlayFab.ClientModels;
using PlayFab;

[RequireComponent(typeof(PhotonView))]
public class PLAYFABSellingManager : MonoBehaviourPunCallbacks
{
    public NetworkingType Type;
    public string CurrencyCode;

    [Header("Editor")]
    public List<SellingItem> ItemsToSell = new List<SellingItem>();

    private void OnTriggerEnter(Collider other)
    {
        if (other.TryGetComponent<SellingItem>(out SellingItem i))
        {
            ItemsToSell.Add(i);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.TryGetComponent<SellingItem>(out SellingItem i))
        {
            ItemsToSell.Remove(i);
        }
    }

    public void SellItems()
    {
        if (Type == NetworkingType.All)
        {
            photonView.RPC(nameof(AddMoney), RpcTarget.All);
        }
        else
        {
            AddMoney();
        }
        photonView.RPC(nameof(Delete), RpcTarget.AllBuffered);
    }

    [PunRPC]
    public void AddMoney()
    {
        int total = 0;
        foreach (SellingItem i in ItemsToSell)
        {
            total += i.SellAmount;
            AddCurrency(total);
        }
    }

    public void AddCurrency(int AddAmount)
    {
        var request = new AddUserVirtualCurrencyRequest
        {
            VirtualCurrency = CurrencyCode,
            Amount = AddAmount
        };

        PlayFabClientAPI.AddUserVirtualCurrency(request, OnCurrencyAdded, OnError);
    }
    private void OnCurrencyAdded(ModifyUserVirtualCurrencyResult result)
    {
        Debug.Log("Added the currency");
    }
    private void OnError(PlayFabError error)
    {
        Debug.Log("An error occurred while modifying the currency");
    }

    [PunRPC]
    public void Delete()
    {
        foreach (SellingItem i in ItemsToSell)
        {
            Destroy(i.gameObject);
        }
    }

    public enum NetworkingType
    {
        All,
        DeleteOnly
    }
}
