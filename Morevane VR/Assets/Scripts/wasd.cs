using GorillaLocomotion;
using UnityEngine;

public class wasd : MonoBehaviour
{
    [Header("WASD\nBy: Instel\nASP3CT?, this one isnt chat gpt lol\nrealleh")]
    public float moveSpeed = 0.1f;
    public float runSpeed = 0.3f;
    public float lookSpeed = 3f;
    public string handTag = "HandTag";
    public bool lockCursor;
    public bool disableGrav;

    private float currentSpeed;
    private GameObject clickthing;
    private Renderer ballrenderer;
    private SphereCollider ballcollider;

    private Ray ray;
    private RaycastHit hit;
    private Camera cam;
    private bool toolate;

    private void Start()
    {
        // click thing
        clickthing = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        clickthing.transform.localScale = Vector3.one * 0.05f;
        ballrenderer = clickthing.GetComponent<Renderer>();
        ballcollider = clickthing.GetComponent<SphereCollider>();
        clickthing.AddComponent<Rigidbody>();
        clickthing.GetComponent<Rigidbody>().isKinematic = true;
        clickthing.tag = handTag;
        ballcollider.isTrigger = true;

        // camera
        cam = Camera.main;
    }

    void Update()
    {
        if (disableGrav)
        {
            Player.Instance.gameObject.GetComponent<Rigidbody>().isKinematic = true;
        }

        // look
        if (Input.GetMouseButton(1))
        {
            Player.Instance.transform.Rotate(new Vector3(-Input.GetAxis("Mouse Y") * lookSpeed, Input.GetAxis("Mouse X") * lookSpeed, 0));
            if (lockCursor)
            {
                Cursor.lockState = CursorLockMode.Locked;
            }
        }
        else
        {
            Cursor.lockState = CursorLockMode.None;
        }
        Player.Instance.transform.eulerAngles = new Vector3(Player.Instance.gameObject.transform.eulerAngles.x, Player.Instance.gameObject.transform.eulerAngles.y, 0f);

        // run
        if (Input.GetKey(KeyCode.LeftShift))
        {
            currentSpeed = runSpeed;
        }
        else
        {
            currentSpeed = moveSpeed;
        }

        // move
        if (Input.GetKey(KeyCode.W))
        {
            Player.Instance.transform.position += Player.Instance.transform.forward * currentSpeed;
            Player.Instance.gameObject.GetComponent<Rigidbody>().isKinematic = true;
        }
        else
        {
            if (!disableGrav)
            {
                Player.Instance.gameObject.GetComponent<Rigidbody>().isKinematic = false;
            }
        }

        if (Input.GetKey(KeyCode.S))
        {
            Player.Instance.transform.position -= Player.Instance.transform.forward * currentSpeed;
            Player.Instance.gameObject.GetComponent<Rigidbody>().isKinematic = true;
        }
        if (Input.GetKey(KeyCode.A))
        {
            Player.Instance.transform.position -= Player.Instance.transform.right * currentSpeed;
            Player.Instance.gameObject.GetComponent<Rigidbody>().isKinematic = true;
        }
        if (Input.GetKey(KeyCode.D))
        {
            Player.Instance.transform.position += Player.Instance.transform.right * currentSpeed;
            Player.Instance.gameObject.GetComponent<Rigidbody>().isKinematic = true;
        }
        if (Input.GetKey(KeyCode.Q))
        {
            Player.Instance.transform.position -= Player.Instance.transform.up * currentSpeed;
            Player.Instance.gameObject.GetComponent<Rigidbody>().isKinematic = true;
        }
        if (Input.GetKey(KeyCode.E))
        {
            Player.Instance.transform.position += Player.Instance.transform.up * currentSpeed;
            Player.Instance.gameObject.GetComponent<Rigidbody>().isKinematic = true;
        }

        // click
        if (Input.GetMouseButton(0))
        {
            ballrenderer.material.color = Color.red;
            ballcollider.enabled = true;
        }
        else
        {
            ballrenderer.material.color = Color.white;
            ballcollider.enabled = false;
            toolate = false;
        }

        if (Physics.Raycast(cam.transform.position, cam.transform.forward, out RaycastHit hit, 1000f) && !toolate)
        {
            clickthing.transform.position = hit.point;
            toolate = true;
        }
    }
}
