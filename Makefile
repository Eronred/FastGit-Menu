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
		CODE_SIGN_IDENTITY="-" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		DEVELOPMENT_TEAM="" \
		build
	@mkdir -p "$(BUILD_DIR)"
	@cp -R "$(BUILD_DIR)/derived/Build/Products/Release/$(APP_NAME).app" "$(BUILD_DIR)/$(APP_NAME).app"
	@echo "Built: $(BUILD_DIR)/$(APP_NAME).app"

dmg:
	@rm -f "$(BUILD_DIR)/$(DMG_NAME).dmg"
	hdiutil create \
		-volname "$(APP_NAME)" \
		-srcfolder "$(BUILD_DIR)/$(APP_NAME).app" \
		-ov \
		-format UDZO \
		"$(BUILD_DIR)/$(DMG_NAME).dmg"
	@echo "DMG: $(BUILD_DIR)/$(DMG_NAME).dmg"

clean:
	rm -rf "$(BUILD_DIR)"
	xcodebuild clean -scheme "$(SCHEME)" 2>/dev/null || true
