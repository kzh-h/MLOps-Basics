from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# 認証情報を読み込む
creds = service_account.Credentials.from_service_account_file(
    "/app/.dvc/credentials.json",  # JSON形式のキーファイルへのパス
    scopes=["https://www.googleapis.com/auth/drive"],
)

# Google Drive APIクライアントを作成
drive_service = build("drive", "v3", credentials=creds)

# アップロードするファイルの情報
file_name = "example.csv"
file_metadata = {
    "name": file_name,
    "parents": ["11SNbPMh-1Nr4UEM--xPnVY1AQEj4168x"],  # ファイルID(ドライブURIの’folders/’に続く値)
}

# ファイルをアップロード
media = MediaFileUpload(file_name, mimetype="application/csv")
file = (
    drive_service.files()
    .create(
        body=file_metadata,
        media_body=media,
        fields="id",
        supportsAllDrives=True,  # ポイント！
    )
    .execute()
)

print(f'File ID: {file.get("id")}')
