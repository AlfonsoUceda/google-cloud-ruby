# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Speech::Project, :recognize_job, :mock_speech do
  let(:job_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"type.googleapis.com/google.cloud.speech.v1beta1.AsyncRecognizeMetadata\",\"value\":\"CFQSDAi6jKS/BRCwkLafARoMCIeZpL8FEKjRqswC\"}}" }
  let(:job_grpc) { Google::Longrunning::Operation.decode_json job_json }

  it "recognizes audio from local file path" do
    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    audio_grpc = Google::Cloud::Speech::V1beta1::RecognitionAudio.new(content: File.read("acceptance/data/audio.raw", mode: "rb"))

    mock = Minitest::Mock.new
    mock.expect :async_recognize, job_grpc, [config_grpc, audio_grpc]

    speech.service.mocked_service = mock
    job = speech.recognize_job "acceptance/data/audio.raw", encoding: :raw, sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Results::Job
    job.wont_be :done?
  end

  it "recognizes audio from local file object" do
    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    audio_grpc = Google::Cloud::Speech::V1beta1::RecognitionAudio.new(content: File.read("acceptance/data/audio.raw", mode: "rb"))

    mock = Minitest::Mock.new
    mock.expect :async_recognize, job_grpc, [config_grpc, audio_grpc]

    speech.service.mocked_service = mock
    job = speech.recognize_job File.open("acceptance/data/audio.raw", "rb"), encoding: :raw, sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Results::Job
    job.wont_be :done?
  end

  it "recognizes audio from GCS URL" do
    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    audio_grpc = Google::Cloud::Speech::V1beta1::RecognitionAudio.new(uri: "gs://some_bucket/audio.raw")

    mock = Minitest::Mock.new
    mock.expect :async_recognize, job_grpc, [config_grpc, audio_grpc]

    speech.service.mocked_service = mock
    job = speech.recognize_job "gs://some_bucket/audio.raw", encoding: :raw, sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Results::Job
    job.wont_be :done?
  end

  it "recognizes audio from Storage File URL" do
    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    audio_grpc = Google::Cloud::Speech::V1beta1::RecognitionAudio.new(uri: "gs://some_bucket/audio.raw")

    mock = Minitest::Mock.new
    mock.expect :async_recognize, job_grpc, [config_grpc, audio_grpc]

    speech.service.mocked_service = mock
    gcs_fake = OpenStruct.new to_gs_url: "gs://some_bucket/audio.raw"
    job = speech.recognize_job gcs_fake, encoding: :raw, sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Results::Job
    job.wont_be :done?
  end
end
