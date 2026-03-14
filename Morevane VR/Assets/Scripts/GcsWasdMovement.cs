using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class GcsWasdMovement : MonoBehaviour
{
    [Header("Made by Glitched Cat Studios\nPlease give credits!")]
    [Space]

    public bool movementEnabled = false;
    [Space(20)]
    public float speedMultiplier = 5f;
    public float jumpForce = 5f;
    public float mouseSensitivity = 1.0f;

    private Rigidbody rb;
    private Camera cam;
    private bool grounded;
    private bool rotating;

    
    private void FixedUpdate()
    {
#if UNITY_EDITOR
        if (movementEnabled)
        {
            Vector3 dir = Vector3.zero;

            if (Input.GetKey(KeyCode.W)) dir += Vector3.forward;
            if (Input.GetKey(KeyCode.A)) dir += Vector3.left;
            if (Input.GetKey(KeyCode.S)) dir += Vector3.back;
            if (Input.GetKey(KeyCode.D)) dir += Vector3.right;

            dir = transform.TransformDirection(dir) * speedMultiplier;

#if UNITY_6000_0_OR_NEWER
            rb.linearVelocity = new Vector3(dir.x, rb.linearVelocity.y, dir.z);
#else
            rb.velocity = new Vector3(dir.x, rb.velocity.y, dir.z);
#endif
            if (grounded && Input.GetKeyDown(KeyCode.Space)) rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);

            if (Input.GetMouseButtonDown(1))
            {
                Cursor.lockState = CursorLockMode.Locked;
                rotating = true;
            }
            else if (Input.GetMouseButtonUp(1))
            {
                Cursor.lockState = CursorLockMode.None;
                rotating = false;
            }

            if (rotating)
            {
                float mx = Input.GetAxis("Mouse X") * mouseSensitivity;
                float my = Input.GetAxis("Mouse Y") * mouseSensitivity;

                transform.Rotate(Vector3.up, mx);
                cam.transform.Rotate(Vector3.right, -my);
            }
        }
#endif
    }

    private void Awake() => (cam, rb) = (Camera.main, GetComponent<Rigidbody>());
    private void OnCollisionStay(Collision collision) => grounded = true;
    private void OnCollisionExit(Collision collision) => grounded = false;
}
