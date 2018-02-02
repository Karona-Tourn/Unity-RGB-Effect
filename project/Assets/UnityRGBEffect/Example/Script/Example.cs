using UnityEngine;
using UnityEngine.UI;

public class Example : MonoBehaviour
{
	public RawImage image = null;

	private void Start()
	{
		Material material = new Material(Shader.Find("Custom/UI/RGB Effect"));
		image.material = material;
	}

	private void ChangeEffect(string name, float value)
	{
		Material material = image.material;
		material.SetFloat(name, value);
	}

	public void ChangeContrast(float value)
	{
		ChangeEffect("_Contrast", value);
	}

	public void ChangeBrightness(float value)
	{
		ChangeEffect("_Brightness", value);
	}

	public void ChangeCyanRed(float value)
	{
		ChangeEffect("_CyanRed", value);
	}

	public void ChangeMagentaGreen(float value)
	{
		ChangeEffect("_MagentaGreen", value);
	}

	public void ChangeYellowBlue(float value)
	{
		ChangeEffect("_YellowBlue", value);
	}

	public void ChangeHue(float value)
	{
		ChangeEffect("_Hue", value);
	}

	public void ChangeSaturation(float value)
	{
		ChangeEffect("_Saturation", value);
	}

	public void ChangeLightness(float value)
	{
		ChangeEffect("_Lightness", value);
	}

	public void OnReset()
	{
		var sliders = GetComponentsInChildren<Slider>();
		foreach (var slider in sliders)
		{
			slider.value = 0f;
		}
	}
}
