//
// SPDX-FileCopyrightText: 2024 HPA Cloud and HPACloud contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//

import UIKit
import ReplayKit

extension RPSystemBroadcastPickerView {
    func showPicker() {
        self.subviews.compactMap { $0 as? UIButton } .forEach { $0.sendActions(for: .touchUpInside )}
    }
}
