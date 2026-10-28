.class public Lcom/officecli/pocket/DownloadHandler;
.super Ljava/lang/Object;
.implements Landroid/webkit/DownloadListener;
.source "DownloadHandler.java"

.field private final activity:Landroid/app/Activity;

.method public constructor <init>(Landroid/app/Activity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/officecli/pocket/DownloadHandler;->activity:Landroid/app/Activity;
    return-void
.end method

.method public onDownloadStart(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;J)V
    .locals 5
    :try_start
    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v0
    new-instance v1, Landroid/app/DownloadManager$Request;
    invoke-direct {v1, v0}, Landroid/app/DownloadManager$Request;-><init>(Landroid/net/Uri;)V
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/app/DownloadManager$Request;->setNotificationVisibility(I)Landroid/app/DownloadManager$Request;
    const-string v2, "application/zip"
    invoke-virtual {v1, v2}, Landroid/app/DownloadManager$Request;->setMimeType(Ljava/lang/String;)Landroid/app/DownloadManager$Request;
    iget-object v2, p0, Lcom/officecli/pocket/DownloadHandler;->activity:Landroid/app/Activity;
    sget-object v3, Landroid/os/Environment;->DIRECTORY_DOWNLOADS:Ljava/lang/String;
    const-string v4, "OfficeCLI-source.zip"
    invoke-virtual {v1, v2, v3, v4}, Landroid/app/DownloadManager$Request;->setDestinationInExternalFilesDir(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V
    iget-object v2, p0, Lcom/officecli/pocket/DownloadHandler;->activity:Landroid/app/Activity;
    const-string v3, "download"
    invoke-virtual {v2, v3}, Landroid/app/Activity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Landroid/app/DownloadManager;
    invoke-virtual {v2, v1}, Landroid/app/DownloadManager;->enqueue(Landroid/app/DownloadManager$Request;)J
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch
    return-void
    :catch
    move-exception v0
    return-void
.end method
