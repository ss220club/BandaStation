import { beforeEach, describe, expect, it } from 'bun:test';

import { ChannelIterator } from './ChannelIterator';

describe('ChannelIterator', () => {
  let channelIterator: ChannelIterator;

  beforeEach(() => {
    channelIterator = new ChannelIterator();
  });

  it('should cycle through channels properly', () => {
    // BANDASTATION EDIT START
    console.log('Available channels:', channelIterator.channels);
    expect(channelIterator.current()).toBe('Говор');
    expect(channelIterator.next()).toBe('Радио');
    expect(channelIterator.next()).toBe('Эмоц');
    expect(channelIterator.next()).toBe('Шёпот');
    expect(channelIterator.next()).toBe('OOC');
    expect(channelIterator.next()).toBe('LOOC');
    expect(channelIterator.next()).toBe('Говор'); // Admin is blacklisted so it should be skipped
    // BANDASTATION EDIT END
  });

  it('should set a channel properly', () => {
    channelIterator.set('OOC');
    expect(channelIterator.current()).toBe('OOC');
  });

  it('should return true when current channel is "Say"', () => {
    channelIterator.set('Говор'); // BANDASTATION EDIT
    expect(channelIterator.isSay()).toBe(true);
  });

  it('should return false when current channel is not "Say"', () => {
    channelIterator.set('Радио'); // BANDASTATION EDIT
    expect(channelIterator.isSay()).toBe(false);
  });

  it('should return true when current channel is visible', () => {
    channelIterator.set('Говор'); // BANDASTATION EDIT
    expect(channelIterator.isVisible()).toBe(true);
  });

  it('should return false when current channel is not visible', () => {
    channelIterator.set('OOC');
    expect(channelIterator.isVisible()).toBe(false);
  });

  it('should not leak a message from a blacklisted channel', () => {
    channelIterator.set('Admin');
    expect(channelIterator.next()).toBe('Admin');
  });
});
