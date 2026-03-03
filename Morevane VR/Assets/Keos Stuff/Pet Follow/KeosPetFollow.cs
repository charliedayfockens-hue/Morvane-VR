using Photon.Pun;
using UnityEngine;

[RequireComponent(typeof(PhotonView))]
[RequireComponent(typeof(PhotonTransformView))]
public class KeosPetFollow : MonoBehaviour
{
    public Transform Player;
    public float Speed = 5f;
    public float Smoothness = 0.3f;
    public Vector3 Offset;

    public LayerMask NotGroundLayer;

    private Vector3 velocity = Vector3.zero;

    private void Awake()
    {
        DontDestroyOnLoad(this);
    }

    private void Update()
    {
        if (Player == null)
            return;

        Vector3 rotatedOffset = Player.rotation * Offset;
        Vector3 pos = Player.position + rotatedOffset;

        Ray ray = new Ray(pos + Vector3.up, Vector3.down);
        if (Physics.Raycast(ray, out RaycastHit Hit))
        {
            if ((NotGroundLayer & (1 << Hit.collider.gameObject.layer)) == 0)
            {
                pos.y = Hit.point.y;
            }
        }

        transform.position = Vector3.SmoothDamp(transform.position, pos, ref velocity, Smoothness, Speed);
        transform.rotation = Quaternion.Slerp(transform.rotation, Player.rotation, Smoothness);
    }
}
