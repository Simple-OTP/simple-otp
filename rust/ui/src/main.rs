use druid::widget::{Button, Align, Flex, Label, TextBox};
use druid::{AppLauncher, LocalizedString, Widget, WidgetExt, WindowDesc, Data, Env, Lens};
use std::env;

const VERTICAL_WIDGET_SPACING: f64 = 20.0;
const TEXT_BOX_WIDTH: f64 = 200.0;
const WINDOW_TITLE: LocalizedString<TOTPState> = LocalizedString::new("One Time Password!");

#[derive(Clone, Data, Lens)]
struct TOTPState {
    secret: String,
    token: String,
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Usage: {} <secret>", args[0]);
        return;
    }

    let main_window = WindowDesc::new(build_root_widget())
        .title(WINDOW_TITLE)
        .window_size((400.0, 400.0));

    let initial_state = TOTPState {
        secret: args[1].clone(),
        token: otp::otp_for(&args[1]).unwrap().into(),
    };

    // start the application
    AppLauncher::with_window(main_window)
        .launch(initial_state)
        .expect("Failed to launch application");
}



fn build_root_widget() -> impl Widget<TOTPState> {

    // a label that will determine its text based on the current app data.
    let label = Label::new(|data: &TOTPState, _env: &Env| format!("OTP {}", data.token));
    // a textbox that modifies `name`.
    let textbox = TextBox::new()
        .with_placeholder("One Time Code?")
        .fix_width(TEXT_BOX_WIDTH)
        .lens(TOTPState::token);

    // arrange the two widgets vertically, with some padding
    let layout = Flex::column()
        .with_child(label)
        .with_spacer(VERTICAL_WIDGET_SPACING)
        .with_child(textbox);

    // center the two widgets in the available space
    Align::centered(layout)
}