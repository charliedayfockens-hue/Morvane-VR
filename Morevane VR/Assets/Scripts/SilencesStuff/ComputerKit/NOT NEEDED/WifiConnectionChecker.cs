using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Resources;
using System.Net.NetworkInformation;
using System.Net.WebSockets;
using Photon.Pun;
public class WifiConnectionChecker : MonoBehaviour
{
    public TMPro.TextMeshPro textMeshPro;
    public List<GameObject> disableOnWifiDisconnection = new List<GameObject> ();
    public List<GameObject> enableOnWifiDisconnection = new List<GameObject>();
    void Update()
    {
        if (NetworkInterface.GetIsNetworkAvailable())
        {
            textMeshPro.text = "Wifi Connected!";
            foreach (GameObject obj in disableOnWifiDisconnection)
            {
                obj.SetActive(true);
            }
            foreach (GameObject obj in enableOnWifiDisconnection)
            {
                obj.SetActive(false);
            }
            Debug.Log("wifi on");
        }
        else
        {
            textMeshPro.text = "Wifi Is Not Connected \nPlease Check Your Wifi If you want to contiune!";
            PhotonNetwork.Disconnect();
            foreach (GameObject obj in disableOnWifiDisconnection)
            {
                obj.SetActive(false);
            }
            foreach (GameObject obj in enableOnWifiDisconnection)
            {
                obj.SetActive(true);
            }
            Debug.Log("wifi off");
        }
    }
}
