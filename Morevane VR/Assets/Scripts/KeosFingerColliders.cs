using Photon.Pun;
using UnityEngine;

public class KeosFingerColliders : MonoBehaviour
{
    [Header("This script was made by Keo.cs")]
    [Header("You do not have to give credits")]
    public PhotonView photonView;
    public GameObject leftCollider;
    public GameObject rightCollider;
    public Transform leftBone;
    public Transform rightBone;

    void Start()
    {
        if (photonView.IsMine)
        {
            leftCollider.SetActive(true);
            rightCollider.SetActive(true);
        }
        else
        {
            leftCollider.SetActive(false);
            rightCollider.SetActive(false);
        }
    }

    void Update()
    {
        if (photonView.IsMine)
        {
            leftCollider.transform.position = leftBone.position;
            leftCollider.transform.rotation = leftBone.rotation;
            rightCollider.transform.position = rightBone.position;
            rightCollider.transform.rotation = rightBone.rotation;
        }
    }
}
