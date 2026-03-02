//
// SPDX-FileCopyrightText: 2024 HPA Cloud and HPACloud contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//

class CustomPresentableNavigationController: UINavigationController, CustomPresentable {
    var dismissalGestureEnabled: Bool = true
    var transitionManager: UIViewControllerTransitioningDelegate?
}
