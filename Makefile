SCHEME = FastGit Menu
BUILD_DIR = build
APP_NAME = FastGit Menu
DMG_NAME = FastGit-Menu

.PHONY: build build-ci archive dmg clean

build:
	xcodebuild \
		-scheme "$(SCHEME)" \
		-configuration Release \
		-derivedDataPath "$(BUILD_DIR)/derived" \
		build
	@mkdir -p "$(BUILD_DIR)"
	@cp -R "$(BUILD_DIR)/derived/Build/Products/Release/$(APP_NAME).app" "$(BUILD_DIR)/$(APP_NAME).app"
	@echo "Built: $(BUILD_DIR)/$(APP_NAME).app"

build-ci:
	xcodebuild \
		-scheme "$(SCHEME)" \
		-configuration Release \
		-derivedDataPath "$(BUILD_DIR)/derived" \
		CODE_SIGN_STYLE=Manual \
		CODE_SIGN_IDENTITY="Developer ID Application" \
		CODE_SIGNING_REQUIRED=YES \
		CODE_SIGNING_ALLOWED=YES \
		DEVELOPMENT_TEAM=ZF9P9LGM63 \
		PROVISIONING_PROFILE_SPECIFIER="" \
		OTHER_CODE_SIGN_FLAGS="--timestamp" \
		CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
		build
	@mkdir -p "$(BUILD_DIR)"
	@cp -R "$(BUILD_DIR)/derived/Build/Products/Release/$(APP_NAME).app" "$(BUILD_DIR)/$(APP_NAME).app"
	@echo "Built: $(BUILD_DIR)/$(APP_NAME).app"

dmg:
	@rm -f "$(BUILD_DIR)/$(DMG_NAME).dmg"
	@rm -rf "$(BUILD_DIR)/dmg-staging"
	@mkdir -p "$(BUILD_DIR)/dmg-staging"
	@cp -R "$(BUILD_DIR)/$(APP_NAME).app" "$(BUILD_DIR)/dmg-staging/"
	@ln -s /Applications "$(BUILD_DIR)/dmg-staging/Applications"
	hdiutil create \
		-volname "$(APP_NAME)" \
		-srcfolder "$(BUILD_DIR)/dmg-staging" \
		-ov \
		-format UDZO \
		"$(BUILD_DIR)/$(DMG_NAME).dmg"
	@rm -rf "$(BUILD_DIR)/dmg-staging"
	@echo "DMG: $(BUILD_DIR)/$(DMG_NAME).dmg"

clean:
	rm -rf "$(BUILD_DIR)"
	xcodebuild clean -scheme "$(SCHEME)" 2>/dev/null || true
