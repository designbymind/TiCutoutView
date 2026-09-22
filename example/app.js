const CutoutView = require('ti.cutoutview');

const window = Ti.UI.createWindow({
	backgroundColor: '#EDE7F7',
	title: 'TiCutoutView 0.3.0'
});

const backdrop = Ti.UI.createView({
	top: 72,
	left: 24,
	right: 24,
	height: 470,
	backgroundGradient: {
		type: 'linear',
		startPoint: {x: '0%', y: '0%'},
		endPoint: {x: '100%', y: '100%'},
		colors: ['#8EC5FC', '#E0C3FC', '#FBC2EB']
	}
});

const panel = CutoutView.createView({
	cutoutPlacement: CutoutView.PLACEMENT_BOTTOM_LEFT,
	cutoutShape: CutoutView.SHAPE_RECTANGLE,
	cutoutSize: {width: 112, height: 84},
	cutoutCornerRadius: 18,
	cutoutCenterOffset: {x: 0, y: 0},
	cutoutSmoothing: 12,

	material: CutoutView.MATERIAL_GLASS,
	glassStyle: CutoutView.GLASS_STYLE_REGULAR,
	glassTintColor: '#20FFFFFF',
	glassInteractive: true,

	cornerRadius: 24,
	borderColor: '#A0FFFFFF',
	borderWidth: 1,
	shadowColor: '#241A32',
	shadowOpacity: 0.24,
	shadowRadius: 14,
	shadowOffset: {x: 0, y: 6},
	clipContentToShape: true,
	shapeAwareHitTesting: true,

	left: 46,
	right: 14,
	top: 28,
	height: 350
});

panel.add(
	Ti.UI.createLabel({
		text: 'Rectangular glass cutout',
		top: 34,
		left: 28,
		right: 28,
		color: '#21172B',
		font: {fontSize: 26, fontWeight: 'bold'}
	})
);

panel.add(
	Ti.UI.createLabel({
		text: 'The glass, border, shadow, child clipping, and hit testing all follow the same rounded-rectangle path.',
		top: 88,
		left: 28,
		right: 28,
		color: '#463B50',
		font: {fontSize: 17}
	})
);

const avatar = Ti.UI.createView({
	left: -6,
	top: 340,
	width: 104,
	height: 76,
	borderRadius: 16,
	borderColor: '#FFFFFF',
	borderWidth: 4,
	backgroundColor: '#6F4C8B',
	zIndex: 2
});

avatar.add(
	Ti.UI.createLabel({
		text: 'JM',
		color: '#FFFFFF',
		font: {fontSize: 30, fontWeight: 'bold'}
	})
);

const animateButton = Ti.UI.createButton({
	title: 'Expand rectangle cutout',
	top: 570,
	left: 34,
	right: 34,
	height: 48
});

let expanded = false;
animateButton.addEventListener('click', () => {
	expanded = !expanded;
	panel.animateCutout({
		cutoutSize: expanded ? {width: 132, height: 100} : {width: 112, height: 84},
		cutoutCornerRadius: expanded ? 28 : 18,
		cutoutSmoothing: expanded ? 16 : 12,
		duration: 750,
		timing: 'spring',
		dampingRatio: 0.78,
		respectReducedMotion: true
	});
	animateButton.title = expanded ? 'Restore rectangle cutout' : 'Expand rectangle cutout';
});

panel.addEventListener('cutoutanimationcomplete', (event) => {
	Ti.API.info(`[TiCutoutView] animation finished: ${event.finished}`);
});

backdrop.add(panel);
backdrop.add(avatar);
window.add(backdrop);
window.add(animateButton);
window.open();
