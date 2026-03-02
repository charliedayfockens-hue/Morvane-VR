using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class DisplayColor : MonoBehaviour
{
    [Header("Made by sev :)")]
    public ColorScript ColorScript;
    [Space]
    [Header("Disply which color? (Select only one)")]
    public bool Red;
    public bool Green;
    public bool Blue;
    private TMP_Text colortext;
    // Start is called before the first frame update
    void Start()
    {
        colortext = GetComponent<TMP_Text>();
    }

    // Update is called once per frame
    void Update()
    {
        if(Red)
        {
            colortext.text = "Red: " + ColorScript.Red;
        }
        if(Blue)
        {
            colortext.text = "Blue: " + ColorScript.Green;
        }
        if(Green)
        {
            colortext.text = "Green: " + ColorScript.Blue;
        }
    }
}
