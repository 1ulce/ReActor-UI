# NVIDIA CUDA 11.8 と Python 3.9 ベースイメージを使用
# FROM nvidia/cuda:11.8.0-base-ubuntu20.04 → baseはcudaしか入ってない
# FROM nvidia/cuda:12.3.0-runtime-ubuntu22.04 → そもそも推奨バージョンと違うし、cudnnを使うことはできるが入ってない
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

# Python 3.9 の PPA 追加
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa

# 必要なパッケージのインストール
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata python3.9 python3.9-dev python3.9-distutils python3.9-tk git-all ffmpeg && \
    apt-get install -y python3-pip build-essential gcc g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Python 3.9 をデフォルトに設定
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# 作業ディレクトリの設定
WORKDIR /app

# ローカルのrequirements.txtをコンテナの作業ディレクトリにコピー
COPY run.py .
COPY requirements.txt .
COPY modules/ ./modules/
COPY data/ ./data/

# Python 依存関係のインストール
RUN pip install -r requirements.txt

# onnxruntime関連パッケージのアンインストールとインストール
RUN pip uninstall -y onnxruntime onnxruntime-gpu && \
    pip install onnxruntime-gpu==1.15.1

# CUDA ToolkitとcuDNNはベースイメージに含まれているため、別途インストールは不要

# Dockerコンテナが起動するときに実行されるコマンド（例）
CMD ["/bin/bash"]
