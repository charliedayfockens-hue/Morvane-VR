using UnityEngine;
using System.Collections;
using UnityEngine.XR;

public class ButtonPress : MonoBehaviour
{
    public Color pressColor = Color.red;
    public string triggeringTag = "HandTag";
    public float colorChangeDuration = 0.05f;

    public bool playSoundOnPress = false;
    public AudioSource pressAudioSource;

    public bool vibrateOnPress = false;
    public bool vibrateLeftController = true;
    public float vibrationDuration = 0.05f;
    public float vibrationAmplitude = 0.15f;

    private Material originalMaterial;
    private Color originalColor;
    private bool isColorChanged = false;

    private void Start()
    {
        originalMaterial = GetComponent<Renderer>().material;
        originalColor = originalMaterial.color;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(triggeringTag) && !isColorChanged)
        {
            StartCoroutine(ChangeColorTemporarily());

            if (playSoundOnPress && pressAudioSource != null)
            {
                pressAudioSource.Play();
            }

            if (vibrateOnPress)
            {
                StartCoroutine(VibrateController());
            }
        }
    }

    private IEnumerator ChangeColorTemporarily()
    {
        isColorChanged = true;
        originalMaterial.color = pressColor;

        yield return new WaitForSeconds(colorChangeDuration);

        originalMaterial.color = originalColor;
        isColorChanged = false;
    }

    private IEnumerator VibrateController()
    {
        InputDevice device = vibrateLeftController ? InputDevices.GetDeviceAtXRNode(XRNode.LeftHand) : InputDevices.GetDeviceAtXRNode(XRNode.RightHand);
        HapticCapabilities capabilities;

        if (device.TryGetHapticCapabilities(out capabilities) && capabilities.supportsImpulse)
        {
            uint channel = 0;
            device.SendHapticImpulse(channel, vibrationAmplitude, vibrationDuration);
            yield return new WaitForSeconds(vibrationDuration);
            device.StopHaptics();
        }
    }
}
