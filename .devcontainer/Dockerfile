# Flutter development container — supports Web, Linux, Android (via host ADB)
FROM ubuntu:22.04

ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_HOME=/opt/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies + Linux desktop toolchain
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk-headless \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK (stable channel)
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Install Android SDK command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
         -O /tmp/cmdtools.zip && \
    unzip -q /tmp/cmdtools.zip -d $ANDROID_HOME/cmdline-tools && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm /tmp/cmdtools.zip

# Accept Android licenses and install SDK components
RUN yes | sdkmanager --licenses > /dev/null 2>&1 && \
    sdkmanager \
        "platform-tools" \
        "platforms;android-35" \
        "build-tools;35.0.0"

# Precache Flutter artifacts for all in-container platforms
RUN flutter precache --linux --android --web

WORKDIR /workspace
