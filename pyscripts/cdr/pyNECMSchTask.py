import re
import codecs
import locale
import sched
import sys
# https://docs.python.org/2/library/sched.html
import threading
import time
import argparse


def get_system_encoding():
    """
    The encoding of the default system locale but falls back to the given
    fallback encoding if the encoding is unsupported by python or could
    not be determined.  See tickets #10335 and #5846
    """
    try:
        encoding = locale.getdefaultlocale()[1] or 'ascii'
        codecs.lookup(encoding)
    except LookupError:
        encoding = 'ascii'
    return encoding


DEFAULT_LOCALE_ENCODING = get_system_encoding()


def shutdown_NetEaseCloudMusic(name):
    # define NetEaseCloudMusic process name
    ProcessNameToKill = name

    print
    import psutil
    import sys

    # learn from getpass.getuser()
    def getuser():
        """Get the username from the environment or password database.
        First try various environment variables, then the password
        database.  This works on Windows as long as USERNAME is set.
        """

        import os

        for username in ('LOGNAME', 'USER', 'LNAME', 'USERNAME'):
            user = os.environ.get(username)
            if user:
                return user

    currentUserName = getuser()

    if ProcessNameToKill in [x.name() for x in psutil.process_iter()]:
        print ("[I] 进程 \"%s\" 被找到了！" % ProcessNameToKill)
    else:
        print ("[E] 进程 \"%s\" 没有运行！" % ProcessNameToKill)
        sys.exit(1)

    for process in psutil.process_iter():
        if process.name() == ProcessNameToKill:
            try:
                # root user can only kill its process, but can NOT kill other users process
                if process.username().endswith(currentUserName):
                    process.kill()
                    print ("[I] 进程 \"%s(pid=%s)\" 以成功被关闭！" % (process.name(), process.pid))
            except Exception as e:
                print (e)


def display_countdown(sec):
    def countdown(secs):
        """
        blocking process 1
        :param secs: seconds, int
        :return:
        """
        current_time = time.strftime("%Y-%m-%d %H:%M:%S %Z").encode("utf-8").decode(DEFAULT_LOCALE_ENCODING)
        print ("开始时间: %s" % current_time)
        while secs:
            now = time.strftime("%Y-%m-%d %H:%M:%S %Z").encode("utf-8").decode(DEFAULT_LOCALE_ENCODING)
            hours, seconds = divmod(secs, 3600)
            minutes, seconds = divmod(seconds, 60)
            clock_format = '{:02d}:{:02d}:{:02d}'.format(hours, minutes, seconds)
            sys.stdout.write('\r当前时间: %s 倒计时: %s' % (now, clock_format))
            sys.stdout.flush()
            time.sleep(1)
            secs -= 1

    # set a human readable timer here, such as display how much time left to shutdown
    countdown(int(sec))


def display_scheduler(name):
    """
    blocking process 2
    :return:
    """
    s = sched.scheduler(time.time, time.sleep)
    # https://docs.python.org/2/library/sched.html#sched.scheduler.enter
    s.enter(seconds_to_shutdown, 1, shutdown_NetEaseCloudMusic, (name,))
    s.run()
    now = time.strftime("%Y-%m-%d %H:%M:%S %Z").encode("utf-8").decode(DEFAULT_LOCALE_ENCODING)
    print ("倒计时结束: %s\n再见!" % now)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='manual to this script')
    parser.add_argument("--time", type=int, default=30)
    args = parser.parse_args()
    # minutes = sys.argv[1]
    # # 默认30分钟
    # if not minutes:
    #     minutes = 30
    seconds_to_shutdown = args.time*60  # after 10s shutdown cloudmusic.exe

    if re.match('^win\w+$',sys.platform): 
        process_name_to_shutdown = "cloudmusic.exe"
    else:
        process_name_to_shutdown = "NeteaseMusic"

    threadingPool = list()
    threading_1 = threading.Thread(target=display_countdown, args=(seconds_to_shutdown,))
    threading_2 = threading.Thread(target=display_scheduler, args=(process_name_to_shutdown,))
    threadingPool.append(threading_1)
    threadingPool.append(threading_2)

    for thread in threadingPool:
        thread.setDaemon(False)
        thread.start()

    thread.join()
