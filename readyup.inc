#if defined  _readyup_included_
        #endinput
#endif
#define _readyup_included_

/**
 * Adds the string to the bottom of the ready-up panel.
 * String must be <=65 characters including the null byte.
 * String will be entirely added or not added, no truncation.
 *
 * @param footer    String to add to the footer
 * @return          True if the string was added, false otherwise
 */
native bool:AddStringToReadyFooter(const String:footer[]);

/**
 * Whether or not the game is currently waiting for players to ready up.
 *
 * @return          True if the game is currently in the ready-up phase.
 */
native bool:IsInReady()

/**
 * Called when the live countdown ends and the round goes live
 */
forward OnRoundIsLive();

// vim: ft=sourcepawn et sw=8
