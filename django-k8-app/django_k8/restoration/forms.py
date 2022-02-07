from django import forms


class ImageForm(forms.Form):
    image = forms.ImageField(label=False)
    image.widget.attrs.update({'class': 'file-upload-input',
                               "onchange": "readURL(this);",})
