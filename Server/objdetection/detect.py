import sys
import time
import threading
import torch

from models.experimental import attempt_load
from utils.datasets import ImageQueue
from utils.general import check_img_size, non_max_suppression, scale_coords, xyxy2xywh, set_logging
from utils.torch_utils import select_device, TracedModel

imgqueue = ImageQueue()
inference_cond = threading.Condition()
ready_lock = threading.Lock()
ready_lock.acquire()
worker_stop = [False]
worker_thread = None

def notify_worker():
    with inference_cond:
        if imgqueue.qsize() != 0:
            inference_cond.notify_all()


class ResultObject(object):
    def __init__(self, id, class_num, xpos, ypos, width, height):
        self.id = id
        self.class_num = class_num
        self.xpos = xpos
        self.ypos = ypos
        self.width = width
        self.height = height


def worker(stop, weights, device, imgsz=640, augment=True):
    t0 = time.time()

    # Initialize
    set_logging()
    device = select_device(device)

    # Load model
    model = attempt_load(weights, map_location=device)  # load FP32 model
    stride = int(model.stride.max())  # model stride
    imgsz = check_img_size(imgsz, s=stride)  # check img_size

    model = TracedModel(model, device, imgsz)

    # Run inference
    if device.type != 'cpu':
        model(torch.zeros(1, 3, imgsz, imgsz).to(device).type_as(next(model.parameters())))  # run once
    old_img_w = old_img_h = imgsz
    old_img_b = 1

    ready_lock.release()

    print(f'Ready. Elapsed time: {time.time() - t0:.3f}s')

    with inference_cond:
        inference_cond.wait()

    while not worker_stop[0]:
        img, im0, callback = imgqueue.get()

        img = torch.from_numpy(img).to(device)
        img = img.float()  # uint8 to fp16/32
        img /= 255.0  # 0 - 255 to 0.0 - 1.0
        if img.ndimension() == 3:
            img = img.unsqueeze(0)

        # Warmup
        if device.type != 'cpu' and (
                old_img_b != img.shape[0] or old_img_h != img.shape[2] or old_img_w != img.shape[3]):
            old_img_b = img.shape[0]
            old_img_h = img.shape[2]
            old_img_w = img.shape[3]
            for i in range(3):
                model(img, augment=augment)[0]

        # Inference
        pred = model(img, augment=augment)[0]

        # Apply NMS
        pred = non_max_suppression(pred, 0.25, 0.45, None, None)

        results = []
        id = 0

        # Process detections
        for _, det in enumerate(pred):  # detections per image
            gn = torch.tensor(im0.shape)[[1, 0, 1, 0]]  # normalization gain whwh
            if len(det):
                # Rescale boxes from img_size to im0 size
                det[:, :4] = scale_coords(img.shape[2:], det[:, :4], im0.shape).round()

                # Write results
                for *xyxy, _, cls in reversed(det):
                    xywh = xyxy[:2]
                    xywh.append(xyxy[2] - xyxy[0])
                    xywh.append(xyxy[3] - xyxy[1])
                    results.append(ResultObject(id, cls, *xywh))

                    id += 1

        print('Inference finished for image ', flush=True)

        if callback is not None:
            callback(results)

        with inference_cond:
            inference_cond.wait()


def start_worker(weights, device, imgsz=640, augment=True):
    if 'manage.py' in sys.argv:
        print('Object detector(YOLOR/YOLOv7) not available in test mode', flush=True)
    else:
        print('Starting object detector', flush=True)
        global worker_thread, worker_stop
        worker_thread = threading.Thread(target = worker, args=(worker_stop, weights, device, imgsz, augment, ))
        worker_thread.start()


def stop_worker():
    global worker_thread, worker_stop, inference_con
    worker_stop = [True]

    with inference_cond:
        inference_cond.notify_all()
    worker_thread.join()


def request_inference(callback, img):
    ready_lock.acquire()
    ready_lock.release()
    imgqueue.put(callback, img)
    notify_worker()
