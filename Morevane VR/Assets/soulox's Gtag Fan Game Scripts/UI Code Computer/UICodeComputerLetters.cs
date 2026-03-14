using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class PMCodeComputerLettersUI : MonoBehaviour
{
    public CodeManager manager;

    public string Letter;
    public bool IsALetter;
    public bool BackSpace;

    public float Delay = 0.1f;
    public int MaxLength = 4;

    private Image buttonImage;
    private Color oldColor;

    private void Awake()
    {
        buttonImage = GetComponent<Image>();
        oldColor = buttonImage.color;
    }

    // Hook this up to the Button's OnClick event
    public void OnButtonPressed()
    {
        StartCoroutine(ColorFlash());
        StartCoroutine(DelayWorks());
    }

    private IEnumerator ColorFlash()
    {
        buttonImage.color = Color.red;
        yield return new WaitForSeconds(0.5f);
        buttonImage.color = oldColor;
    }

    private IEnumerator DelayWorks()
    {
        yield return new WaitForSeconds(Delay);

        // Backspace always allowed
        if (BackSpace && manager.NewRoomThingy.Length > 0)
        {
            manager.NewRoomThingy =
                manager.NewRoomThingy.Remove(manager.NewRoomThingy.Length - 1);
            yield break;
        }

        // Block input if max length reached
        if (IsALetter && manager.NewRoomThingy.Length >= MaxLength)
        {
            yield break;
        }

        // Add letter
        if (IsALetter)
        {
            manager.NewRoomThingy += Letter;
        }
    }
}
