using UnityEngine;
using UnityEditor;

public class LabGenerator : MonoBehaviour
{
    [Header("This script was made by Keo.cs")]
    public int labWidth = 10;
    public int labHeight = 10;
    public float roomSize = 5f;
    public float wallHeight = 2.5f;
    public float wallThickness = 0.2f;
    public Material floorMaterial;
    public Material wallMaterial;
    public Material roofMaterial;
    public bool randomSeed = true;
    public int specifiedSeed = 0;
    public Transform floorParent;  // Parent for floor objects
    public Transform wallParent;   // Parent for wall objects
    public Transform roofParent;   // Parent for roof objects

    private int currentSeed;

    private void Start()
    {
        RegenerateLab();
    }

    public void RegenerateLab()
    {
        DestroyOldLab();
        GenerateLab();
    }

    private void GenerateLab()
    {
        if (randomSeed)
        {
            currentSeed = Random.Range(0, int.MaxValue);
        }
        else
        {
            currentSeed = specifiedSeed;
        }

        Random.InitState(currentSeed);

        for (int x = 0; x < labWidth; x++)
        {
            for (int y = 0; y < labHeight; y++)
            {
                CreateFloor(x, y);
                CreateWalls(x, y);
                CreateRoof(x, y);
            }
        }
        CreateBoundaryWalls();
    }

    private void CreateFloor(int x, int y)
    {
        GameObject floor = GameObject.CreatePrimitive(PrimitiveType.Cube);
        floor.transform.position = new Vector3(x * roomSize, -wallThickness / 2, y * roomSize);
        floor.transform.localScale = new Vector3(roomSize, wallThickness, roomSize);
        floor.GetComponent<Renderer>().material = floorMaterial;
        floor.tag = "LabObject";
        floor.transform.parent = floorParent; // Set the parent
    }

    private void CreateWalls(int x, int y)
    {
        if (Random.Range(0, 2) == 0)
        {
            CreateWall(new Vector3(x * roomSize, wallHeight / 2, y * roomSize + roomSize / 2), new Vector3(roomSize, wallHeight, wallThickness));
        }

        if (Random.Range(0, 2) == 0)
        {
            CreateWall(new Vector3(x * roomSize + roomSize / 2, wallHeight / 2, y * roomSize), new Vector3(wallThickness, wallHeight, roomSize));
        }
    }

    private void CreateWall(Vector3 position, Vector3 scale)
    {
        GameObject wall = GameObject.CreatePrimitive(PrimitiveType.Cube);
        wall.transform.position = position;
        wall.transform.localScale = scale;
        wall.GetComponent<Renderer>().material = wallMaterial;
        wall.tag = "LabObject";
        wall.transform.parent = wallParent; // Set the parent
    }

    private void CreateRoof(int x, int y)
    {
        GameObject roof = GameObject.CreatePrimitive(PrimitiveType.Cube);
        roof.transform.position = new Vector3(x * roomSize, wallHeight, y * roomSize);
        roof.transform.localScale = new Vector3(roomSize, wallThickness, roomSize);
        roof.GetComponent<Renderer>().material = roofMaterial;
        roof.tag = "LabObject";
        roof.transform.parent = roofParent; // Set the parent
    }

    private void CreateBoundaryWalls()
    {
        for (int x = -1; x <= labWidth; x++)
        {
            CreateWall(new Vector3(x * roomSize, wallHeight / 2, -roomSize / 2), new Vector3(roomSize, wallHeight, wallThickness));
            CreateWall(new Vector3(x * roomSize, wallHeight / 2, labHeight * roomSize - roomSize / 2), new Vector3(roomSize, wallHeight, wallThickness));
        }

        for (int y = 0; y < labHeight; y++)
        {
            CreateWall(new Vector3(-roomSize / 2, wallHeight / 2, y * roomSize), new Vector3(wallThickness, wallHeight, roomSize));
            CreateWall(new Vector3(labWidth * roomSize - roomSize / 2, wallHeight / 2, y * roomSize), new Vector3(wallThickness, wallHeight, roomSize));
        }
    }

    private void DestroyOldLab()
    {
        GameObject[] labObjects = GameObject.FindGameObjectsWithTag("LabObject");
        foreach (GameObject obj in labObjects)
        {
            Destroy(obj);
        }
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(LabGenerator))]
public class LabGeneratorEditor : Editor
{
    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        DrawDefaultInspector();

        LabGenerator labGenerator = (LabGenerator)target;

        EditorGUILayout.Space();

        if (GUILayout.Button("Regenerate Lab"))
        {
            labGenerator.RegenerateLab();
        }

        serializedObject.ApplyModifiedProperties();
    }
}
#endif
