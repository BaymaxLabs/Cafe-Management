import Flutter
import FirebaseAuth
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    handleFirebaseAuthURLs(connectionOptions.urlContexts)
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if handleFirebaseAuthURLs(URLContexts) {
      return
    }
    super.scene(scene, openURLContexts: URLContexts)
  }

  private func handleFirebaseAuthURLs(_ urlContexts: Set<UIOpenURLContext>) -> Bool {
    for urlContext in urlContexts {
      if Auth.auth().canHandle(urlContext.url) {
        return true
      }
    }
    return false
  }
}
