import UIAbility from "@ohos:app.ability.UIAbility";
import type window from "@ohos:window";
import type Want from "@ohos:app.ability.Want";
import type AbilityConstant from "@ohos:app.ability.AbilityConstant";
export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        console.info('[EntryAbility] onCreate');
    }
    onDestroy(): void {
        console.info('[EntryAbility] onDestroy');
    }
    onWindowStageCreate(windowStage: window.WindowStage): void {
        console.info('[EntryAbility] onWindowStageCreate');
        windowStage.loadContent('pages/Index', (err: Error): void => {
            if (err) {
                console.error(`[EntryAbility] Failed to load the content. Error: ${err.message}`);
                return;
            }
            console.info('[EntryAbility] Succeeded in loading the content.');
        });
    }
    onWindowStageDestroy(): void {
        console.info('[EntryAbility] onWindowStageDestroy');
    }
    onForeground(): void {
        console.info('[EntryAbility] onForeground');
    }
    onBackground(): void {
        console.info('[EntryAbility] onBackground');
    }
}
