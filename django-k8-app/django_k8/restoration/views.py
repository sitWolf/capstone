import time
import os
import secrets
import base64

import boto3

from django.shortcuts import render
from django.views.generic import TemplateView

from .forms import ImageForm
from config.settings.base import MEDIA_ROOT
from config.settings.production import (S3_BUCKET_IN_NAME,
                                        S3_BUCKET_OUT_NAME,
                                        AWS_S3_REGION_NAME,
                                        AWS_ACCESS_KEY_ID,
                                        AWS_SECRET_ACCESS_KEY)


def handle_uploaded_file(file):
    request_id = secrets.token_hex(15)
    s3 = boto3.resource('s3',
                        aws_access_key_id=AWS_ACCESS_KEY_ID,
                        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                        region_name=AWS_S3_REGION_NAME)
    bucket_in = s3.Bucket(S3_BUCKET_IN_NAME)
    bucket_out = s3.Bucket(S3_BUCKET_OUT_NAME)
    file_string = file.read()
    bucket_in.put_object(
        Body=file_string,
        Key=request_id,
    )
    return check_for_output(request_id, bucket_out)


def test_upload(file, name, bucket):
    bucket.put_object(
        Body=file,
        Key=f"output/{name}",
    )


def unable_to_process_gif():
    file_path = os.path.join(MEDIA_ROOT, "unable", "little-britain-computer-says-no.gif")
    with open(file_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read())
        base64_ = encoded_string.decode('utf-8')
        base64rep = f"data:image/gif;base64,{base64_}"
        return base64rep


def sample_images_base64(sample_image_path):
    file_path = os.path.join(MEDIA_ROOT, "sample", sample_image_path)
    with open(file_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read())
        base64_ = encoded_string.decode('utf-8')
        base64rep = f"data:image/jpg;base64,{base64_}"
        return base64rep


def s3object_to_base64(file):
    encoded_string = base64.b64encode(file)
    base64_ = encoded_string.decode('utf-8')
    base64rep = f"data:image/png;base64,{base64_}"
    return base64rep


def check_for_output(request_id, bucket):
    attempts = 12
    sleep_time = 5

    for i in range(attempts):
        time.sleep(sleep_time)
        try:
            output_object = bucket.Object(request_id).get()
            return output_object['Body'].read()
        except:
            continue
    return None


class HomePageView(TemplateView):
    template_name = "restoration/index.html"

    def get(self, request, **kwargs):
        form = ImageForm()
        samples = sample_images_base64("albert.jpg")
        return render(request, self.template_name, {"form": form, "samples": samples})

    def post(self, request, **kwargs):
        form = ImageForm(request.POST, request.FILES)
        samples = sample_images_base64("albert.jpg")

        if form.is_valid():
            # TODO: get inference output image from S3
            # Save image to media
            reconstructed_image = handle_uploaded_file(request.FILES['image'])
            if reconstructed_image:
                base_64_image = s3object_to_base64(reconstructed_image)
                return render(request, self.template_name, {"form": form, "image": base_64_image, "samples": samples})
            else:
                return render(request, self.template_name, {"form": form, "image": unable_to_process_gif(), "samples": samples})
        else:
            return render(request, self.template_name, {"form": form, "samples": samples})
