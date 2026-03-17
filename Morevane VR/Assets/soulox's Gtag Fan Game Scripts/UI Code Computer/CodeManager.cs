using UnityEngine;
using Photon.Pun;
using TMPro;

public class CodeManager : MonoBehaviour
{
    [Header("credit primal monke/rtx4090 or you arnt sigma and made for UI support by soulox")]
    [Space]

    public TextMeshProUGUI InRoomText;

    [Space]
    [Header("dont touch this")]

    public string NewRoomThingy;
    public TextMeshProUGUI NewRoomText;

    private void Update()
    {
        // Update typed code
        NewRoomText.text = NewRoomThingy;

        // Update room status
        if (PhotonNetwork.InRoom)
        {
            InRoomText.text = PhotonNetwork.CurrentRoom.Name;
        }
        else
        {
            InRoomText.text = "Not In Room";
        }
    }
}
