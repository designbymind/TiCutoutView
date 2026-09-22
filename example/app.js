const CutoutView = require('ti.cutoutview');

let expanded = false;

const window = Ti.UI.createWindow({
	width: Ti.UI.FILL,
	height: Ti.UI.FILL,
	backgroundColor: Ti.UI.userInterfaceStyle === 1 ? '#FFFFFF' : '#000000'
});

window.add(
	Ti.UI.createImageView({
		image: Ti.UI.userInterfaceStyle === 1 ? 'images/iOS-27-Blue.jpg' : 'images/iOS-27-Dark-Ink.jpg',
		width: Ti.UI.FILL,
		height: Ti.UI.FILL,
		scalingMode: Ti.Media.IMAGE_SCALING_ASPECT_FILL,
		preventDefaultImage: true
	})
);

const wrapper = Ti.UI.createView({
	width: Ti.UI.FILL,
	height: Ti.UI.SIZE,
	left: 12,
	right: 12
});

const panel = CutoutView.createView({
	cutoutPlacement: CutoutView.PLACEMENT_BOTTOM_LEFT,
	cutoutShape: CutoutView.SHAPE_CIRCLE,
	cutoutRadius: 34,
	cutoutCenterOffset: { x: 0, y: 0 },
	cutoutSmoothing: 8,
	// iOS 26+ Liquid Glass
	material: CutoutView.MATERIAL_GLASS,
	glassStyle: CutoutView.GLASS_STYLE_REGULAR,
	// glassTintColor: '#20FFFFFF',
	glassInteractive: true,
	// View Styles
	cornerRadius: 24,
	borderColor: Ti.UI.userInterfaceStyle === 1 ? '#FFFFFF' : '#000000',
	borderWidth: 1,
	// shadowColor: 'rgba(0, 0, 0, 0.24)',
	// shadowRadius: 6,
	// shadowOffset: { x: 0, y: 0 },
	clipContentToShape: true,
	shapeAwareHitTesting: true,
	width: Ti.UI.FILL,
	height: 200,
	top: 1, // whenever panel (CutoutView) has a border that touched display/viewport edge, use the border width as a margin for each of those edges
	left: 32,
	right: 1 // whenever panel (CutoutView) has a border that touched display/viewport edge, use the border width as a margin for each of those edges
});

panel.add(
	Ti.UI.createView({
		backgroundColor: Ti.UI.userInterfaceStyle === 1 ? 'rgba(0, 0, 0, 0.3)' : 'rgba(255, 255, 255, 0.3)',
		width: Ti.UI.FILL,
		height: 16,
		top: 24,
		left: 24,
		right: 24,
		borderRadius: 8
	})
);

panel.add(
	Ti.UI.createView({
		backgroundColor: Ti.UI.userInterfaceStyle === 1 ? 'rgba(0, 0, 0, 0.15)' : 'rgba(255, 255, 255, 0.15)',
		width: Ti.UI.FILL,
		height: 12,
		top: 52,
		left: 24,
		right: 24,
		borderRadius: 6
	})
);

panel.add(
	Ti.UI.createView({
		backgroundColor: Ti.UI.userInterfaceStyle === 1 ? 'rgba(0, 0, 0, 0.15)' : 'rgba(255, 255, 255, 0.15)',
		width: '50%',
		height: 12,
		top: 76,
		left: 24,
		right: 24,
		borderRadius: 6
	})
);

const avatar = Ti.UI.createView({
	left: 0,
	top: 172,
	width: 60,
	height: 60,
	borderRadius: 30,
	borderColor: Ti.UI.userInterfaceStyle === 1 ? '#FFFFFF' : '#000000',
	borderWidth: 1,
	backgroundColor: Ti.UI.userInterfaceStyle === 1 ? '#000000' : '#FFFFFF',
	zIndex: 2
});

avatar.add(
	Ti.UI.createLabel({
		text: '¯\\_(ツ)_/¯',
		color: Ti.UI.userInterfaceStyle === 1 ? '#FFFFFF' : '#000000',
		font: { fontSize: 10, fontWeight: 'bold' }
	})
);

const animateButton = Ti.UI.createButton({
	top: 300,
	left: 34,
	right: 34,
	height: 48,
	tintColor: '#FFFFFF',
	font: { fontSize: 14, fontWeight: 'semibold' }
});

animateButton.title = expanded ? 'restore cutout' : 'expand cutout';

animateButton.addEventListener('click', () => {
	expanded = !expanded;
	panel.animateCutout({
		cutoutRadius: expanded ? 66 : 34,
		cutoutSmoothing: expanded ? 16 : 8,
		duration: 750,
		timing: 'spring',
		dampingRatio: 0.78,
		respectReducedMotion: true
	});
	animateButton.title = expanded ? 'restore cutout' : 'expand cutout';
});

panel.addEventListener('cutoutanimationcomplete', (event) => {
	Ti.API.info(`[TiCutoutView] animation finished: ${event.finished}`);
});

wrapper.add(panel);
wrapper.add(avatar);
window.add(wrapper);
window.add(animateButton);
window.open();
