FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as builder

# Set the current directory
WORKDIR /source

# Copy solutions and projects one by one to the current directory
COPY *.sln ./
COPY ./src/Api/Api.csproj ./src/Api/Api.csproj
COPY ./src/Application/Application.csproj ./src/Application/Application.csproj
COPY ./tests/Api.Tests/Api.Tests.csproj ./tests/Api.Tests/Api.Tests.csproj
COPY ./tests/Application.Tests/Application.Tests.csproj ./tests/Application.Tests/Application.Tests.csproj

# Run the restore of dependencies
RUN dotnet restore -r linux-musl-x64 
    #--source https://proget.fftech.info/Farfetch-Nuget-DEV/

COPY src/Api/. ./src/Api/

# Run publish
RUN dotnet publish ./src/Api/Api.csproj -c Release \
    -r linux-musl-x64 \
    -o /app \
    --self-contained true \
    /p:PublishSingleFile=true \
    /p:PublishTr\immed=true 


FROM alpine:latest

RUN apk --no-cache add \
    ca-certificates \
    icu-libs \
    libintl

# Uncomment to enable globalization APIs
# ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT false
# ENV LC_ALL en_US.UTF-8
# ENV LANG en_US.UTF-8

WORKDIR /app

COPY --from=builder /app ./

RUN ls -lah

EXPOSE 80

ENTRYPOINT [ "./Api" ]