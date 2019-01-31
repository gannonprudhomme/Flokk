# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

def sharedPods
    use_frameworks!
    
    # Pods for Flokk
    pod "NextLevel", "~> 0.9.8"
    pod "SwiftyJSON", "~> 4.0"
    pod "Texture"
    pod 'PromisesSwift'
    
    # Firebase Pods
    pod "Firebase/Core"
    pod "Firebase/Auth"
    pod "Firebase/Database"
    pod "Firebase/Storage"
end

target 'Flokk' do
    sharedPods
end

target 'FlokkTests' do
    sharedPods
end
