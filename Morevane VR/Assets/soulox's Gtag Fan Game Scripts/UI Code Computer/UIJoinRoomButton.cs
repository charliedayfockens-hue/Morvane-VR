using UnityEngine;
using Photon.Pun;

public class PhotonVRDisconnectButton : MonoBehaviour
{
    // Hook this up to a UI Button OnClick()
    public void OnDisconnectPressed()
    {
        if (!PhotonNetwork.IsConnected)
            return;

        PhotonNetwork.Disconnect();
    }
}
